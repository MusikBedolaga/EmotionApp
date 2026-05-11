package com.example.content.dtos.album;

import com.example.content.dtos.topic.TopicShortDto;
import lombok.Builder;
import lombok.Data;

import java.util.Date;
import java.util.Set;

@Data
@Builder
public class AlbumResponseDto {

    Long id;
    String title;
    String description;
    Long userId;
    Date createdAt;
    Set<TopicShortDto> topics;
}
