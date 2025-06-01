package com.ai.triptailor;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class TriptailorApplication {

	public static void main(String[] args) {
		SpringApplication.run(TriptailorApplication.class, args);
	}

}
