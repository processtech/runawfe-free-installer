package com.izforge.izpack.panels.userinput.processor;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import com.izforge.izpack.panels.userinput.processorclient.ProcessingClient;

/**
 * Автоматически определяет HTTP/HTTPS порт и протокол сервера RunaWFE.
 */
public class ServerPortDetectorProcessor implements Processor {

    private static final int[] HTTP_PORTS = { 80, 8080, 8081, 8082, 8083, 8084, 8085, 8180 };
    private static final int[] HTTPS_PORTS = { 443, 8443 };
    private static final int TIMEOUT_SECONDS = 3;
    private static final String FALLBACK = "8080|http";
    private static final String URL_PATH = "/wfe/";
    private static final HttpClient HTTP_CLIENT = createHttpClient();

    private enum ServerState {
        DEAD,
        ALIVE,
        REDIRECT_TO_HTTPS
    }

    @Override
    public String process(ProcessingClient client) {
        if (client == null)
            return FALLBACK;
        String host = client.getFieldContents(0);
        if (host == null || host.trim().isEmpty())
            return FALLBACK;
        return detect(host.trim());
    }

    private String detect(String host) {
        if (HTTP_CLIENT == null)
            return FALLBACK;
        CompletableFuture<String> finalResult = new CompletableFuture<>();
        int totalPorts = HTTP_PORTS.length + HTTPS_PORTS.length;
        AtomicInteger activeChecks = new AtomicInteger(totalPorts);
        // Контейнеры для накопления результатов проверки
        AtomicReference<String> foundHttps = new AtomicReference<>(null);
        AtomicReference<String> foundHttp = new AtomicReference<>(null);
        AtomicBoolean foundRedirect = new AtomicBoolean(false);
        for (int port : HTTPS_PORTS) {
            checkServerAsync(host, port, true).thenAccept(res -> {
                if (res.state == ServerState.ALIVE) {
                    foundHttps.compareAndSet(null, res.port + "|https");
                    finalResult.complete(res.port + "|https");
                }
                if (activeChecks.decrementAndGet() == 0) {
                    finalResult.complete(null);
                }
            });
        }
        for (int port : HTTP_PORTS) {
            checkServerAsync(host, port, false).thenAccept(res -> {
                if (res.state == ServerState.ALIVE) {
                    foundHttp.compareAndSet(null, res.port + "|http");
                } else if (res.state == ServerState.REDIRECT_TO_HTTPS) {
                    foundRedirect.set(true);
                }
                // даем возможность всем HTTPS-портам успеть ответить.
                if (activeChecks.decrementAndGet() == 0) {
                    finalResult.complete(null); // Все порты ответили
                }
            });
        }
        try {
            // Ждем завершения. Если нашелся живой HTTPS, возвращаем его.
            // Если нет, ждем окончания остальных проверок, но не дольше таймаута.
            String fastPath = finalResult.get(TIMEOUT_SECONDS + 1, TimeUnit.SECONDS);
            if (fastPath != null)
                return fastPath;

            // Проверяем, подтвердился ли HTTPS (на случай, если он пришел одновременно с концом проверок)
            if (foundHttps.get() != null) {
                return foundHttps.get();
            }
            // Если HTTP-порт сообщил о редиректе, мы проверяем, ожил ли какой-то HTTPS-порт.
            // Если живой HTTPS порт найден — берем его.
            if (foundRedirect.get()) {
                if (foundHttps.get() != null) {
                    return foundHttps.get();
                }
                // Если редирект есть, но указывает на порты,которые мертвы или закрыты файрволом,
                // отдаем рабочий HTTP-порт, который этот редирект прислал.
                if (foundHttp.get() != null) {
                    return foundHttp.get();
                }
            }
            // Если редиректов не было или HTTPS мертв, возвращаем первый найденный живой HTTP
            if (foundHttp.get() != null) {
                return foundHttp.get();
            }
        } catch (Exception e) {
            return FALLBACK;
        }
        return FALLBACK;
    }

    private static class ServerResult {
        final int port;
        final boolean isHttps;
        final ServerState state;

        ServerResult(int port, boolean isHttps, ServerState state) {
            this.port = port;
            this.isHttps = isHttps;
            this.state = state;
        }
    }

    private CompletableFuture<ServerResult> checkServerAsync(String host, int port, boolean isHttps) {
        String protocol = isHttps ? "https" : "http";
        String urlStr = protocol + "://" + host + ":" + port + URL_PATH;
        try {
            HttpRequest request = HttpRequest.newBuilder().uri(URI.create(urlStr)).timeout(Duration.ofSeconds(TIMEOUT_SECONDS)).GET().build();
            return HTTP_CLIENT.sendAsync(request, HttpResponse.BodyHandlers.discarding()).thenApply(response -> {
                int status = response.statusCode();
                if (status >= 200 && status < 400) {
                    if (!isHttps && (status == 301 || status == 302)) {
                        String location = response.headers().firstValue("Location").orElse("");
                        if (location.startsWith("https://")) {
                            return new ServerResult(port, false, ServerState.REDIRECT_TO_HTTPS);
                        }
                    }
                    return new ServerResult(port, isHttps, ServerState.ALIVE);
                }
                return new ServerResult(port, isHttps, ServerState.DEAD);
            }).exceptionally(ex -> new ServerResult(port, isHttps, ServerState.DEAD));
        } catch (Exception e) {
            return CompletableFuture.completedFuture(new ServerResult(port, isHttps, ServerState.DEAD));
        }
    }

    private static HttpClient createHttpClient() {
        try {
            // Доверяем любым SSL-сертификатам. Чтобы сервер мог использовать самоподписанные сертификаты.
            TrustManager[] trustAll = new TrustManager[] { new X509TrustManager() {
                public void checkClientTrusted(X509Certificate[] c, String t) {
                }
                public void checkServerTrusted(X509Certificate[] c, String t) {
                }
                public X509Certificate[] getAcceptedIssuers() {
                    return new X509Certificate[0];
                }
            } };

            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, trustAll, new SecureRandom());
            return HttpClient.newBuilder().sslContext(sslContext).followRedirects(HttpClient.Redirect.NEVER)
                    .connectTimeout(Duration.ofSeconds(TIMEOUT_SECONDS)).build();
        } catch (Exception e) {
            // Если SSL сломался, создаем стандартный клиент для проверки HTTP-портов.
            try {
                return HttpClient.newBuilder().followRedirects(HttpClient.Redirect.NEVER).connectTimeout(Duration.ofSeconds(TIMEOUT_SECONDS)).build();
            } catch (Exception fatal) {
                return null;
            }
        }
    }
}
