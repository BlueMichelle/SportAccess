package com.sportaccess;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class SportAccessApplication {

	public static void main(String[] args) {
		SpringApplication.run(SportAccessApplication.class, args);
	}
}

