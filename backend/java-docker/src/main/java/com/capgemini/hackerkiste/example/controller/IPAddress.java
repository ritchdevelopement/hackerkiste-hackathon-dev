package com.capgemini.hackerkiste.example.controller;

import java.net.InetAddress;

public class IPAddress {

    private InetAddress thisIp;

    private String thisIpAddress;

    private void setIpAdd() {
        try {
            InetAddress thisIp = InetAddress.getLocalHost();
            thisIpAddress = thisIp.getHostAddress().toString();
        } catch (Exception e) {
        }
    }

    protected String getIpAddress() {
        setIpAdd();
        return thisIpAddress;
    }
}
