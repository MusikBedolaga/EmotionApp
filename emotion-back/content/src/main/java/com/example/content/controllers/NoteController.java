package com.example.content.controllers;

import com.example.content.dtos.note.NoteCreateDto;
import com.example.content.dtos.note.NoteResponseDto;
import com.example.content.dtos.note.NoteShortDto;
import com.example.content.dtos.note.NoteUpdateDto;
import com.example.content.services.NoteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.List;

@RestController
@RequestMapping("/api/notes")
@RequiredArgsConstructor
public class NoteController {

    private final NoteService noteService;

    /**
     * Создать заметку
     */
    @PostMapping("/create-note")
    public ResponseEntity<NoteResponseDto> createNote(
            @RequestHeader("X-User-Id") Long userId,
            @Valid @RequestBody NoteCreateDto dto,
            UriComponentsBuilder uriBuilder
    ) {
        NoteResponseDto created = noteService.createNote(userId, dto);
        return ResponseEntity
                .created(uriBuilder.path("/api/notes/{id}")
                        .buildAndExpand(created.getId())
                        .toUri())
                .body(created);
    }

    /**
     * Получить одну заметку по ID
     */
    @GetMapping("/{id}")
    public NoteResponseDto getNoteById(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id
    ) {
        return noteService.getById(userId, id);
    }

    /**
     * Изменить заметку
     */
    @PatchMapping("/{id}")
    public NoteResponseDto updateNote(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id,
            @Valid @RequestBody NoteUpdateDto updateDto
    ) {
        return noteService.updateNote(userId, id, updateDto);
    }

    /**
     * Получить список всех заметок внутри конкретного альбома
     */
    @GetMapping("/album/{albumId}")
    public List<NoteShortDto> getNotesByAlbum(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long albumId
    ) {
        return noteService.listByAlbum(userId, albumId);
    }

    @GetMapping("/recent")
    public List<NoteShortDto> getRecentNotes(
            @RequestHeader("X-User-Id") Long userId,
            @RequestParam(defaultValue = "5") int limit
    ) {
        return noteService.listRecent(userId, limit);
    }

    /**
     * Удалить заметку
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteNote(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id
    ) {
        noteService.delete(userId, id);
        return ResponseEntity.noContent().build(); // HTTP 204
    }
}
