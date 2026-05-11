package com.example.content.dtos.note;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class NoteUpdateDto {

    @NotBlank
    @Size(max = 200)
    String title;
}
