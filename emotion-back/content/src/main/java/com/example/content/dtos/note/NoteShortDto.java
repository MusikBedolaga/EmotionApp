package com.example.content.dtos.note;

import lombok.Builder;
import lombok.Data;

import java.util.Date;

@Data
@Builder
public class NoteShortDto {

    Long id;
    Long albumId;
    String albumTitle;
    String title;
    Date createdAt;
}
