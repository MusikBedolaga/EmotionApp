package com.example.note_ai_broker;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NoteProducer {

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    private static final String TOPIC = "note-events";

    public void sendNoteEvent(String event) {
        // Публикуем событие в Kafka
        kafkaTemplate.send(TOPIC, event);
        System.out.println("Event sent to Kafka: " + event);
    }
}