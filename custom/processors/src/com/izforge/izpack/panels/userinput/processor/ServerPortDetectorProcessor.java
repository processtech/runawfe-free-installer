package com.izforge.izpack.panels.userinput.processor;

import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URL;

import com.izforge.izpack.panels.userinput.processorclient.ProcessingClient;

/**
 * Field processor that auto-detects the HTTP port of a RunaWFE server.
 * <p>
 * Attached to host field this processor attempts to connect to common HTTP ports (@code PORTS) on the specified host using a two-step check:
 * <ol>
 * <li>Fast TCP connect to check if the port is open</li>
 * <li>HTTP GET to {@code URL_PATH} to verify it's a correct server</li>
 * </ol>
 * The first port that passes both checks is returned and written to the variable specified by {@code toVariable}).
 * <p>
 * If none of the ports respond, {@code FALLBACK_PORT} is used as fallback.
 */
public class ServerPortDetectorProcessor implements Processor {

    private static final int[] PORTS = { 80, 8080, 8081, 8082, 8083, 8084, 8085, 8180 };
    private static final int TCP_TIMEOUT_MS = 500;
    private static final int HTTP_TIMEOUT_MS = 5000;
    private static final String FALLBACK_PORT = "8080";
    private static final String URL_PATH = "/wfe/";

    @Override
    public String process(ProcessingClient client) {
        String host = client.getFieldContents(0);
        if (host == null) {
            return FALLBACK_PORT;
        }
        host = host.trim();
        if (host.isEmpty()) {
            return FALLBACK_PORT;
        }
        return detectPort(host);
    }

    private String detectPort(String host) {
        for (int port : PORTS) {
            if (isTcpOpen(host, port) && isServer(host, port)) {
                return String.valueOf(port);
            }
        }
        return FALLBACK_PORT;
    }

    private boolean isTcpOpen(String host, int port) {
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress(host, port), TCP_TIMEOUT_MS);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isServer(String host, int port) {
        HttpURLConnection connection = null;
        try {
            URL url = new URL("http://" + host + ":" + port + URL_PATH);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(HTTP_TIMEOUT_MS);
            connection.setReadTimeout(HTTP_TIMEOUT_MS);
            int responseCode = connection.getResponseCode();
            return (responseCode == HttpURLConnection.HTTP_OK || responseCode == HttpURLConnection.HTTP_MOVED_TEMP
                    || responseCode == HttpURLConnection.HTTP_MOVED_PERM);
        } catch (Exception e) {
            return false;
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
}