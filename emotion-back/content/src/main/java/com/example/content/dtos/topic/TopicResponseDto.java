package com.example.content.dtos.topic;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TopicResponseDto {

    Long id;
    String name;
    String color;
}
