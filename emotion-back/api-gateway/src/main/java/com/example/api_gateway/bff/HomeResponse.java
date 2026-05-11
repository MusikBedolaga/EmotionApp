package com.example.api_gateway.bff;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class HomeResponse {

    private JsonNode albums;
    private JsonNode recentNotes;
    private JsonNode topics;
}
