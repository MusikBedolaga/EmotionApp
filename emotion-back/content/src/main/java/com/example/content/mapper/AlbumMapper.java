package com.example.content.mapper;

import com.example.content.dtos.album.AlbumCreateDto;
import com.example.content.dtos.album.AlbumResponseDto;
import com.example.content.dtos.album.AlbumShortDto;
import com.example.content.dtos.album.AlbumUpdateDto;
import com.example.content.entities.Album;
import org.mapstruct.*;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface AlbumMapper {
    Album toEntity(AlbumCreateDto dto);

    AlbumResponseDto toDto(Album album);

    @Mapping(target = "notesCount",
            expression = "java(album.getNotes() != null ? album.getNotes().size() : 0)")
    AlbumShortDto toShortDto(Album album);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "notes", ignore = true)
    @Mapping(target = "topics", ignore = true)
    void updateEntityFromDto(AlbumUpdateDto dto, @MappingTarget Album album);
}
