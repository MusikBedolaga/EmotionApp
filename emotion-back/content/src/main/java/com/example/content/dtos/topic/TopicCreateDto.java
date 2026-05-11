package com.example.content.dtos.topic;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class TopicCreateDto {

    @NotBlank
    @Size(max = 120)
    String name;

    @NotBlank
    @Size(max = 20)
    String color;
}
