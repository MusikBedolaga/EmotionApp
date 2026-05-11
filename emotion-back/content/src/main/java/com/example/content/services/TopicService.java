package com.example.content.services;

import com.example.content.dtos.topic.TopicCreateDto;
import com.example.content.dtos.topic.TopicShortDto;
import com.example.content.dtos.topic.TopicUpdateDto;
import com.example.content.entities.Topic;
import com.example.content.mapper.TopicMapper;
import com.example.content.repositories.TopicRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashSet;
import java.util.NoSuchElementException;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Transactional
public class TopicService {

    private final TopicRepository repository;
    private final TopicMapper topicMapper;

    public Set<TopicShortDto> getAllTopics() {
        Set<Topic> topics = new HashSet<>(repository.findAll());

        return topicMapper.toShortDtoSet(topics);
    }

    public TopicShortDto createTopic(TopicCreateDto dto) {
        if (repository.existsByNameIgnoreCase(dto.getName())) {
            throw new IllegalArgumentException("Топик с таким названием уже существует");
        }

        Topic topic = topicMapper.toEntity(dto);
        topic.setCreatedAt(new Date());
        topic.setAlbums(new HashSet<>());

        return topicMapper.toShortDto(repository.save(topic));
    }

    public TopicShortDto updateTopic(Long id, TopicUpdateDto dto) {
        Topic topic = repository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Топик не найден"));

        if (dto.getName() != null && repository.existsByNameIgnoreCaseAndIdNot(dto.getName(), id)) {
            throw new IllegalArgumentException("Топик с таким названием уже существует");
        }

        topicMapper.updateEntityFromDto(dto, topic);
        return topicMapper.toShortDto(repository.save(topic));
    }

    public void deleteTopic(Long id) {
        Topic topic = repository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Топик не найден"));

        for (var album : new HashSet<>(topic.getAlbums())) {
            album.getTopics().remove(topic);
        }

        repository.delete(topic);
    }
}

