package com.example.api_gateway.bff;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class HomeService {

    private final WebClient.Builder webClientBuilder;

    @Value("${app.services.content-url}")
    private String contentServiceUrl;

    public Mono<HomeResponse> loadHome(Long userId, int recentNotesLimit) {
        int normalizedLimit = Math.min(Math.max(recentNotesLimit, 1), 50);
        WebClient client = webClientBuilder.baseUrl(contentServiceUrl).build();

        Mono<JsonNode> albumsMono = fetch(client, "/api/albums/all-albums", userId);
        Mono<JsonNode> recentNotesMono = fetch(client, "/api/notes/recent?limit=" + normalizedLimit, userId);
        Mono<JsonNode> topicsMono = fetch(client, "/api/topics", userId);

        return Mono.zip(albumsMono, recentNotesMono, topicsMono)
                .map(tuple -> HomeResponse.builder()
                        .albums(tuple.getT1())
                        .recentNotes(tuple.getT2())
                        .topics(tuple.getT3())
                        .build());
    }

    private Mono<JsonNode> fetch(WebClient client, String uri, Long userId) {
        return client.get()
                .uri(uri)
                .header("X-User-Id", String.valueOf(userId))
                .retrieve()
                .bodyToMono(JsonNode.class);
    }
}
