package com.example.content.dtos.note;

import lombok.Builder;
import lombok.Data;

import java.util.Date;

@Data
@Builder
public class NoteResponseDto {

    Long id;
    Long albumId;
    String title;
    String content;
    Date createdAt;

}
