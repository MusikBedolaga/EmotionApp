package com.example.content.services;

import com.example.content.dtos.note.NoteCreateDto;
import com.example.content.dtos.note.NoteResponseDto;
import com.example.content.dtos.note.NoteShortDto;
import com.example.content.dtos.note.NoteUpdateDto;
import com.example.content.mapper.NoteMapper;
import com.example.content.messaging.NoteEventPublisher;
import com.example.content.repositories.AlbumRepository;
import com.example.content.repositories.NoteRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Transactional
public class NoteService {

    private final NoteRepository repository;
    private final NoteMapper noteMapper;
    private final AlbumRepository albumRepository;
    private final NoteEventPublisher noteEventPublisher;

    public NoteResponseDto createNote(Long userId, NoteCreateDto dto) {
        if (!albumRepository.existsByIdAndUserId(dto.getAlbumId(), userId)) {
            throw new IllegalArgumentException("Альбом не найден или не принадлежит пользователю");
        }

        if (repository.existsByTitleAndAlbum_Id(dto.getTitle(), dto.getAlbumId())) {
            throw new IllegalArgumentException("Заметка с таким названием уже существует в этом альбоме");
        }

        var album = albumRepository.getReferenceById(dto.getAlbumId());

        var note = noteMapper.toEntity(dto);
        note.setCreatedAt(new Date());
        note.setAlbum(album);

        repository.save(note);
        noteEventPublisher.publishCreated(
                note.getId(),
                album.getId(),
                userId,
                note.getTitle(),
                note.getContent()
        );
        return noteMapper.toDto(note);
    }

    public NoteResponseDto updateNote(Long userId, Long id, NoteUpdateDto dto) {
        var note = repository.findById(id)
                .filter(n -> n.getAlbum().getUserId().equals(userId))
                .orElseThrow(() -> new NoSuchElementException("Заметка не найдена"));

        boolean renamed = !note.getTitle().equals(dto.getTitle());
        if (renamed &&
                repository.existsByTitleAndAlbum_IdAndIdNot(dto.getTitle(), note.getAlbum().getId(), id)) {
            throw new IllegalArgumentException("Заметка с таким названием уже существует в этом альбоме");
        }

        noteMapper.updateEntityFromDto(dto, note);
        repository.save(note);

        if (renamed) {
            noteEventPublisher.publishRenamed(
                    note.getId(),
                    note.getAlbum().getId(),
                    userId,
                    note.getTitle(),
                    note.getContent()
            );
        }

        return noteMapper.toDto(note);
    }

    @Transactional(Transactional.TxType.SUPPORTS)
    public NoteResponseDto getById(Long userId, Long noteId) {
        var note = repository.findById(noteId)
                .filter(n -> n.getAlbum().getUserId().equals(userId))
                .orElseThrow(() -> new NoSuchElementException("Заметка не найдена"));

        return noteMapper.toDto(note);
    }

    @Transactional(Transactional.TxType.SUPPORTS)
    public List<NoteShortDto> listByAlbum(Long userId, Long albumId) {
        albumRepository.findByIdAndUserId(albumId, userId)
                .orElseThrow(() -> new NoSuchElementException("Альбом не найден"));

        var notes = repository.findAllByAlbum_Id(albumId);

        return notes.stream()
                .map(noteMapper::toShortDto)
                .toList();
    }

    @Transactional(Transactional.TxType.SUPPORTS)
    public List<NoteShortDto> listRecent(Long userId, int limit) {
        int normalizedLimit = Math.min(Math.max(limit, 1), 50);
        return repository.findAllByAlbum_UserIdOrderByCreatedAtDesc(userId, PageRequest.of(0, normalizedLimit))
                .stream()
                .map(noteMapper::toShortDto)
                .toList();
    }

    public void delete(Long userId, Long noteId) {
        var note = repository.findById(noteId)
                .filter(n -> n.getAlbum().getUserId().equals(userId))
                .orElseThrow(() -> new NoSuchElementException("Заметка не найдена"));

        Long albumId = note.getAlbum().getId();
        String title = note.getTitle();
        String content = note.getContent();

        repository.delete(note);
        noteEventPublisher.publishDeleted(noteId, albumId, userId, title, content);
    }
}
