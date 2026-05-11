package com.example.note_ai_broker;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MessageBrokerController {

    @Autowired
    private NoteProducer noteProducer;

    @PostMapping("/send-note-event")
    public String sendEvent(String event) {
        noteProducer.sendNoteEvent(event);
        return "Event sent!";
    }
}