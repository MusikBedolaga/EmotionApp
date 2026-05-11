package com.example.content.dtos.topic;

import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TopicUpdateDto {

    @Size(max = 120)
    String name;

    @Size(max = 20)
    String color;
}
