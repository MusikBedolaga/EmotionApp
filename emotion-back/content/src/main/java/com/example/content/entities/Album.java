package com.example.content.entities;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.util.*;

@Entity
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
@Table(name = "albums",
        indexes = {
                @Index(name = "idx_album_user", columnList = "user_id")
        })
public class Album {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "album_seq")
    @SequenceGenerator(name = "album_seq", sequenceName = "album_seq", allocationSize = 50)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "description", length = 50)
    private String description;

    @Column(name = "created_at")
    private Date createdAt = new Date();

    @OneToMany(
            mappedBy = "album",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private List<Note> notes = new ArrayList<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "album_topic",
            joinColumns = @JoinColumn(name = "album_id"),
            inverseJoinColumns = @JoinColumn(name = "topic_id"),
            uniqueConstraints = @UniqueConstraint(name="uk_album_topic", columnNames = {"album_id","topic_id"})
    )
    private Set<Topic> topics = new HashSet<>();

    // Хелперы двусторонних связей
    public void addNote(Note note) {
        notes.add(note);
        note.setAlbum(this);
    }
    public void removeNote(Note note) {
        notes.remove(note);
        note.setAlbum(null);
    }
    public void addTopic(Topic topic) {
        topics.add(topic);
        topic.getAlbums().add(this);
    }
    public void removeTopic(Topic topic) {
        topics.remove(topic);
        topic.getAlbums().remove(this);
    }
}
