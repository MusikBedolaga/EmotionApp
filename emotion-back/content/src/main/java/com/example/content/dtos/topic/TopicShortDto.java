package com.example.content.dtos.topic;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TopicShortDto {

    Long id;
    String name;
    String color;
}
