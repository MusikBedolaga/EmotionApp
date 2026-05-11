package com.example.content.mapper;

import com.example.content.dtos.note.NoteCreateDto;
import com.example.content.dtos.note.NoteResponseDto;
import com.example.content.dtos.note.NoteShortDto;
import com.example.content.dtos.note.NoteUpdateDto;
import com.example.content.entities.Note;
import org.mapstruct.*;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface NoteMapper {
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "album", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    Note toEntity(NoteCreateDto dto);

    @Mapping(target = "albumId", source = "album.id")
    NoteResponseDto toDto(Note note);

    @Mapping(target = "albumId", source = "album.id")
    @Mapping(target = "albumTitle", source = "album.title")
    NoteShortDto toShortDto(Note note);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "album", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    void updateEntityFromDto(NoteUpdateDto dto, @MappingTarget Note note);
}
