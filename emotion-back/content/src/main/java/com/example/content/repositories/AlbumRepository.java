package com.example.content.repositories;

import com.example.content.entities.Album;
import com.example.content.entities.Note;
import com.example.content.entities.Topic;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AlbumRepository extends JpaRepository<Album, Long> {

    List<Album> findAllByUserId(Long userId);
    Page<Album> findAllByUserId(Long userId, Pageable pageable);

    boolean existsByIdAndUserId(Long id, Long userId);
    boolean existsByTitle(String title);

    List<Album> findAllByTopicsContains(Topic topic);
    Page<Album> findAllByTopics_Id(Long topicId, Pageable pageable);

    Optional<Album> findByIdAndUserId(Long id, Long userId);

    int deleteByIdAndUserId(Long id, Long userId);

    List<Album> findAllByTopics_Id(Long topicId);
    List<Album> findAllByUserIdAndTopics_Id(Long userId, Long topicId);

    boolean existsByUserIdAndTitleIgnoreCase(Long userId, String title);
    boolean existsByUserIdAndTitleIgnoreCaseAndIdNot(Long userId, String title, Long id);
}
