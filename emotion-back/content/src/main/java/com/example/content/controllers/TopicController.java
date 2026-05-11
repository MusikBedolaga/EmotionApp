package com.example.content.controllers;

import com.example.content.dtos.topic.TopicCreateDto;
import com.example.content.dtos.topic.TopicShortDto;
import com.example.content.dtos.topic.TopicUpdateDto;
import com.example.content.services.TopicService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Set;

@RestController
@RequestMapping("/api/topics")
@RequiredArgsConstructor
public class TopicController {

    private final TopicService topicService;

    @GetMapping
    public ResponseEntity<Set<TopicShortDto>> getAllTopics() {
        Set<TopicShortDto> topics = topicService.getAllTopics();
        return ResponseEntity.ok(topics);
    }

    @PostMapping
    public ResponseEntity<TopicShortDto> createTopic(@Valid @RequestBody TopicCreateDto dto) {
        return ResponseEntity.ok(topicService.createTopic(dto));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<TopicShortDto> updateTopic(
            @PathVariable Long id,
            @Valid @RequestBody TopicUpdateDto dto
    ) {
        return ResponseEntity.ok(topicService.updateTopic(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTopic(@PathVariable Long id) {
        topicService.deleteTopic(id);
        return ResponseEntity.noContent().build();
    }
}
