package com.example.content.mapper;

import com.example.content.dtos.topic.TopicCreateDto;
import com.example.content.dtos.topic.TopicShortDto;
import com.example.content.dtos.topic.TopicUpdateDto;
import com.example.content.entities.Topic;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;
import org.mapstruct.ReportingPolicy;

import java.util.Set;

@Mapper(componentModel = "spring", unmappedTargetPolicy = ReportingPolicy.IGNORE)
public interface TopicMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "albums", ignore = true)
    Topic toEntity(TopicCreateDto dto);

    TopicShortDto toShortDto(Topic topic);

    Set<TopicShortDto> toShortDtoSet(Set<Topic> topics);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "albums", ignore = true)
    void updateEntityFromDto(TopicUpdateDto dto, @MappingTarget Topic topic);
}
