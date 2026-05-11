package com.example.content.messaging;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.time.Instant;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
@RequiredArgsConstructor
public class NoteEventPublisher {

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    @Value("${app.kafka.note-events-topic:note-events}")
    private String noteEventsTopic;

    public void publishCreated(Long noteId, Long albumId, Long userId, String title, String content) {
        publishAfterCommit("note.created", noteId, albumId, userId, title, content);
    }

    public void publishRenamed(Long noteId, Long albumId, Long userId, String title, String content) {
        publishAfterCommit("note.renamed", noteId, albumId, userId, title, content);
    }

    public void publishDeleted(Long noteId, Long albumId, Long userId, String title, String content) {
        publishAfterCommit("note.deleted", noteId, albumId, userId, title, content);
    }

    private void publishAfterCommit(
            String eventType,
            Long noteId,
            Long albumId,
            Long userId,
            String title,
            String content
    ) {
        Runnable publishAction = () -> publish(
                new NoteEventPayload(eventType, noteId, albumId, userId, title, content, Instant.now())
        );
        Runnable asyncPublishAction = () -> CompletableFuture.runAsync(publishAction);

        if (TransactionSynchronizationManager.isActualTransactionActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    asyncPublishAction.run();
                }
            });
            return;
        }

        asyncPublishAction.run();
    }

    private void publish(NoteEventPayload payload) {
        try {
            String message = objectMapper.writeValueAsString(payload);
            kafkaTemplate.send(noteEventsTopic, String.valueOf(payload.noteId()), message)
                    .whenComplete((result, error) -> {
                        if (error != null) {
                            log.warn("Не удалось отправить note event в Kafka", error);
                        }
                    });
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Не удалось сериализовать note event", e);
        }
    }

    private record NoteEventPayload(
            @JsonProperty("event_type") String eventType,
            @JsonProperty("note_id") Long noteId,
            @JsonProperty("album_id") Long albumId,
            @JsonProperty("user_id") Long userId,
            @JsonProperty("title") String title,
            @JsonProperty("content") String content,
            @JsonProperty("occurred_at") Instant occurredAt
    ) {
    }
}
