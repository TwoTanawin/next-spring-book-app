package com.tanawin.BookAPI.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter; // ✅ Correct import

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
                "http://localhost:5001"
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
                "https://*.surge.sh"
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
