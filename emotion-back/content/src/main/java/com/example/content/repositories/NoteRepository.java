package com.example.content.repositories;

import com.example.content.entities.Note;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {

    List<Note> findAllByAlbum_Id(Long albumId);
    Page<Note> findAllByAlbum_Id(Long albumId, Pageable pageable);

    List<Note> findAllByAlbum_UserId(Long userId);
    Page<Note> findAllByAlbum_UserId(Long userId, Pageable pageable);

    boolean existsByIdAndAlbum_UserId(Long noteId, Long userId);
    boolean existsByTitleAndAlbum_Id(String title, Long albumId);
    boolean existsByTitleAndAlbum_IdAndIdNot(String title, Long albumId, Long noteId);

    List<Note> findAllByAlbum_IdAndTitleContainingIgnoreCase(Long albumId, String q);
    Page<Note> findAllByAlbum_UserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    int deleteByIdAndAlbum_UserId(Long noteId, Long userId);
}
