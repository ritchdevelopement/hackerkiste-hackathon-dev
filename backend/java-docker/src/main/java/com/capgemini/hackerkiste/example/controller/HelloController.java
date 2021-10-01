package com.capgemini.hackerkiste.example.controller;

import java.io.IOException;
import java.io.StringWriter;
import java.util.Date;

import org.json.simple.JSONObject;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
//@RequestMapping("docker-java-app")
@RequestMapping("/backend/java")
public class HelloController {
	
	@RequestMapping(value = "", method = RequestMethod.GET)
	public String helloWorld() {
		IPAddress ipAddress = new IPAddress();
		String externalIp = ipAddress.getIpAddress();

		JSONObject jsonObject = new JSONObject();
		jsonObject.put("language_type", "java");
		jsonObject.put("server_ip", externalIp);

		String response = "Failure";
		try {
			StringWriter out = new StringWriter();
			jsonObject.writeJSONString(out);
			response = out.toString();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return response;
	}

}
