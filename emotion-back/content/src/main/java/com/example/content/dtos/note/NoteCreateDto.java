package com.example.content.dtos.note;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class NoteCreateDto {

    @NotNull
    Long albumId;

    @NotBlank
    String title;

    @NotBlank
    String content;
}
