package com.example.note_ai_broker;

import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@EnableKafka
public class NoteConsumer {

    @KafkaListener(topics = "note-events", groupId = "message-broker-group")
    public void consumeNoteEvent(String event) {
        // Здесь обрабатываем событие
        System.out.println("Event received: " + event);

        // Логика для обработки события (например, анализ текста)
        // Например, отправить это событие в другой сервис для анализа
    }
}
