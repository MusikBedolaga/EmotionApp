package com.example.content.dtos.album;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AlbumShortDto {

    Long id;
    String title;
    String description;
    Integer notesCount;
}
