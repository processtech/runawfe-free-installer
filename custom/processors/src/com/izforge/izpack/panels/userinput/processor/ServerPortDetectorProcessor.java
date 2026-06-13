package com.izforge.izpack.panels.userinput.processor;

import com.izforge.izpack.panels.userinput.processorclient.ProcessingClient;

import java.net.InetSocketAddress;
import java.net.Socket;

/**
 * Field processor that auto-detects the HTTP port of a RunaWFE server.
 * <p>
 * Attached to host field this processor attempts to connect 
 * to common HTTP ports (@code PORTS)
 * on the specified host via TCP connect. The first open port is returned and
 * written to the variable specified by {@code toVariable}
 * <p>
 * If none of the ports respond, @code FALLBACK_PORT is used as fallback.
 */
public class ServerPortDetectorProcessor implements Processor {

    private static final int[] PORTS = {8080, 80, 8180, 8081};
    private static final int TIMEOUT_MS = 500;
    private static final String FALLBACK_PORT = "8080";

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
            if (isPortOpen(host, port)) {
                return String.valueOf(port);
            }
        }
        return FALLBACK_PORT;
    }

    private boolean isPortOpen(String host, int port) {
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress(host, port), TIMEOUT_MS);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}