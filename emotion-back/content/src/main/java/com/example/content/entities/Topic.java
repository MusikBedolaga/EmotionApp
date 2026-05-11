package com.example.content.entities;

import jakarta.persistence.*;
import lombok.*;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

@Entity
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
@Table(name = "topics",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_topic_name", columnNames = {"name"})
        })
public class Topic {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "topic_seq")
    @SequenceGenerator(name = "topic_seq", sequenceName = "topic_seq", allocationSize = 50)
    private Long id;

    @Column(name = "name", nullable = false, length = 120)
    private String name;

    @Column(name = "color", nullable = false, length = 20)
    private String color;

    @Column(name = "created_at")
    private Date createdAt = new Date();

    @ManyToMany(mappedBy = "topics", fetch = FetchType.LAZY)
    private Set<Album> albums = new HashSet<>();
}
