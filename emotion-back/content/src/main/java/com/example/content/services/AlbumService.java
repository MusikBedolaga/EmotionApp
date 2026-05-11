package com.example.content.services;

import com.example.content.dtos.album.AlbumCreateDto;
import com.example.content.dtos.album.AlbumResponseDto;
import com.example.content.dtos.album.AlbumShortDto;
import com.example.content.dtos.album.AlbumUpdateDto;
import com.example.content.entities.Album;
import com.example.content.entities.Topic;
import com.example.content.mapper.AlbumMapper;
import com.example.content.repositories.AlbumRepository;
import com.example.content.repositories.TopicRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
@Transactional
public class AlbumService {

    private final AlbumRepository repository;
    private final AlbumMapper albumMapper;
    private final TopicRepository topicRepository;

    public AlbumResponseDto createAlbum(Long userId, AlbumCreateDto dto) {
        if (repository.existsByUserIdAndTitleIgnoreCase(userId, dto.getTitle())) {
            throw new IllegalArgumentException("Альбом с таким названием уже существует");
        }

        Album album = albumMapper.toEntity(dto);
        album.setUserId(userId);
        album.setCreatedAt(new Date());
        album.setNotes(new ArrayList<>());
        album.setTopics(new HashSet<>());

        album = repository.save(album);
        return albumMapper.toDto(album);
    }

    @Transactional
    public AlbumResponseDto updateAlbum(Long userId, Long albumId, AlbumUpdateDto dto) {
        Album album = repository.findByIdAndUserId(albumId, userId)
                .orElseThrow(() -> new NoSuchElementException("Альбом не найден"));

        if (dto.getTitle() != null
                && repository.existsByUserIdAndTitleIgnoreCaseAndIdNot(userId, dto.getTitle(), albumId)) {
            throw new IllegalArgumentException("Альбом с таким названием уже существует");
        }

        albumMapper.updateEntityFromDto(dto, album);

        album = repository.save(album);
        return albumMapper.toDto(album);
    }

    public void deleteAlbum(Long userId, Long albumId) {
        int affected = repository.deleteByIdAndUserId(albumId, userId);
        if (affected == 0) throw new NoSuchElementException("Альбом не найден");
    }

    public List<AlbumShortDto> getAlbumsByTopic(Long userId, Long topicId) {
        List<Album> albums = repository.findAllByUserIdAndTopics_Id(userId, topicId);

        return albums.stream()
                .map(albumMapper::toShortDto)
                .toList();
    }

    public AlbumResponseDto getAlbum(Long userId, Long id) {
        var album = repository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new NoSuchElementException("Альбом не найден"));

        return albumMapper.toDto(album);
    }

    public List<AlbumResponseDto> getAllAlbums(Long userId) {
        var albums = repository.findAllByUserId(userId);

        return albums.stream()
                .map(albumMapper::toDto)
                .toList();
    }

    public AlbumResponseDto addTopicToAlbum(Long userId, Long albumId, Long topicId) {
        Album album = repository.findByIdAndUserId(albumId, userId)
                .orElseThrow(() -> new NoSuchElementException("Альбом не найден"));
        Topic topic = topicRepository.findById(topicId)
                .orElseThrow(() -> new NoSuchElementException("Топик не найден"));

        boolean alreadyAssigned = album.getTopics().stream()
                .anyMatch(existing -> Objects.equals(existing.getId(), topicId));
        if (!alreadyAssigned) {
            album.addTopic(topic);
        }

        return albumMapper.toDto(repository.save(album));
    }

    public AlbumResponseDto removeTopicFromAlbum(Long userId, Long albumId, Long topicId) {
        Album album = repository.findByIdAndUserId(albumId, userId)
                .orElseThrow(() -> new NoSuchElementException("Альбом не найден"));

        Topic topic = album.getTopics().stream()
                .filter(existing -> Objects.equals(existing.getId(), topicId))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("Топик не привязан к альбому"));

        album.removeTopic(topic);
        return albumMapper.toDto(repository.save(album));
    }
}
