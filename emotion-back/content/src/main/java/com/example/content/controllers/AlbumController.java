package com.example.content.controllers;

import com.example.content.dtos.album.AlbumCreateDto;
import com.example.content.dtos.album.AlbumResponseDto;
import com.example.content.dtos.album.AlbumShortDto;
import com.example.content.dtos.album.AlbumUpdateDto;
import com.example.content.services.AlbumService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/api/albums")
@RequiredArgsConstructor
public class AlbumController {

    private final AlbumService albumService;

    @PostMapping("/create-album")
    public ResponseEntity<AlbumResponseDto> create(
            @RequestHeader("X-User-Id") Long userId,
            @Valid @RequestBody AlbumCreateDto dto,
            UriComponentsBuilder builder
    ) {
        var created = albumService.createAlbum(userId, dto);
        return ResponseEntity
                .created(builder.path("/api/albums/{id}")
                        .buildAndExpand(created.getId()).toUri())
                .body(created);
    }

    @GetMapping("/{id}")
    public AlbumResponseDto get(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id
    ) {
        return albumService.getAlbum(userId, id);
    }

    @PatchMapping("/{id}")
    public AlbumResponseDto update(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id,
            @Valid @RequestBody AlbumUpdateDto dto
    ) {
        return albumService.updateAlbum(userId, id, dto);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id
    ) {
        albumService.deleteAlbum(userId, id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/by-topic/{topicId}")
    public List<AlbumShortDto> byTopic(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long topicId
    ) {
        return albumService.getAlbumsByTopic(userId, topicId);
    }

    @GetMapping("/all-albums")
    public List<AlbumResponseDto> getAll(@RequestHeader("X-User-Id") Long userId) {
        return albumService.getAllAlbums(userId);
    }

    @PutMapping("/{albumId}/topics/{topicId}")
    public AlbumResponseDto addTopic(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long albumId,
            @PathVariable Long topicId
    ) {
        return albumService.addTopicToAlbum(userId, albumId, topicId);
    }

    @DeleteMapping("/{albumId}/topics/{topicId}")
    public AlbumResponseDto removeTopic(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long albumId,
            @PathVariable Long topicId
    ) {
        return albumService.removeTopicFromAlbum(userId, albumId, topicId);
    }
}
