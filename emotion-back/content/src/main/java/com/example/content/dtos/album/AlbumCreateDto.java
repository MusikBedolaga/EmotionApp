package com.example.content.dtos.album;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AlbumCreateDto {

    @NotBlank
    String title;

    @Size(max = 50)
    String description;
}
