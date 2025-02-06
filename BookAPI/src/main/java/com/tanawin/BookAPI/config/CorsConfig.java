package com.tanawin.BookAPI.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter; 

import java.util.List;

@Configuration
public class CorsConfig {
    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);

        // ✅ Set allowed origins using List.of()
        config.setAllowedOrigins(List.of(
                "https://itgenius.co.th",
                "http://localhost:8080",
                "http://localhost:4200",
                "http://localhost:3000",
                "http://localhost:5173",
                "http://localhost:5000",
                "http://localhost:5001",
                // Minikube NodePort URLs
                "http://192.168.49.2:30082",  // Backend NodePort
                "http://192.168.49.2:30083",  // Frontend NodePort
                // Kubernetes Service URLs
                "http://frontend-service.gogreen-app.svc.cluster.local:3000",
                "http://backend-service.gogreen-app.svc.cluster.local:8282"
        ));

        // ✅ Use allowed origin patterns for wildcard domains
        config.setAllowedOriginPatterns(List.of(
                "https://*.itgenius.co.th",
                "https://*.azurewebsites.net",
                "https://*.netlify.app",
                "https://*.vercel.app",
                "https://*.herokuapp.com",
                "https://*.firebaseapp.com",
                "https://*.github.io",
                "https://*.gitlab.io",
                "https://*.onrender.com",
                "https://*.surge.sh",
                // Kubernetes and Minikube patterns
                "http://192.168.49.*:*",      // Minikube IP pattern
                "http://10.96.*.*:*",         // Kubernetes service IP range
                "http://10.244.*.*:*",        // Pod IP range
                "http://10.99.*.*:*",         // Service IP range
                "http://10.102.*.*:*",        // Service IP range
                "http://10.103.*.*:*",        // Service IP range
                "http://10.107.*.*:*",        // Service IP range
                "http://*.gogreen-app.svc.cluster.local:*",  // Kubernetes DNS pattern
                "http://*.svc.cluster.local:*"               // General Kubernetes DNS pattern
        ));

        // ✅ Allow all headers and methods
        config.setAllowedHeaders(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));

        // ✅ Register the CORS configuration
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        return new CorsFilter(source);
    }
}
