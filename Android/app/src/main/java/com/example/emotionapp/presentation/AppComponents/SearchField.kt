package com.example.emotionapp.presentation.AppComponents

import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Composable
fun SearchField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    modifier: Modifier = Modifier,

    enabled: Boolean = true,
    singleLine: Boolean = true,

    containerColor: Color = MaterialTheme.colorScheme.surfaceVariant,
    placeholderColor: Color = MaterialTheme.colorScheme.onSurfaceVariant,
    textColor: Color = MaterialTheme.colorScheme.onSurface,
    iconColor: Color = MaterialTheme.colorScheme.onSurfaceVariant,

    shape: Shape = androidx.compose.foundation.shape.RoundedCornerShape(14.dp),
    contentPadding: PaddingValues = PaddingValues(horizontal = 14.dp, vertical = 10.dp),

    leadingIcon: (@Composable () -> Unit)? = null,
) {
    val interactionSource = remember { MutableInteractionSource() }

    val colors = TextFieldDefaults.colors(
        focusedContainerColor = containerColor,
        unfocusedContainerColor = containerColor,
        disabledContainerColor = containerColor.copy(alpha = 0.6f),

        focusedIndicatorColor = Color.Transparent,
        unfocusedIndicatorColor = Color.Transparent,
        disabledIndicatorColor = Color.Transparent,

        cursorColor = textColor,
        focusedTextColor = textColor,
        unfocusedTextColor = textColor,
        disabledTextColor = textColor.copy(alpha = 0.6f),

        focusedLeadingIconColor = iconColor,
        unfocusedLeadingIconColor = iconColor,
        disabledLeadingIconColor = iconColor.copy(alpha = 0.6f),

        focusedPlaceholderColor = placeholderColor,
        unfocusedPlaceholderColor = placeholderColor,
        disabledPlaceholderColor = placeholderColor.copy(alpha = 0.6f),
    )

    val resolvedLeadingIcon: @Composable (() -> Unit) = leadingIcon ?: {
        Icon(
            imageVector = Icons.Default.Search,
            contentDescription = null,
            tint = iconColor
        )
    }

    BasicTextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = 44.dp),
        enabled = enabled,
        singleLine = singleLine,
        textStyle = MaterialTheme.typography.bodyLarge.merge(TextStyle(color = textColor)),
        cursorBrush = SolidColor(textColor),
        interactionSource = interactionSource,
        visualTransformation = VisualTransformation.None,
        decorationBox = { innerTextField ->
            TextFieldDefaults.DecorationBox(
                value = value,
                innerTextField = innerTextField,
                enabled = enabled,
                singleLine = singleLine,
                visualTransformation = VisualTransformation.None,
                interactionSource = interactionSource,
                placeholder = {
                    Text(
                        text = placeholder,
                        color = placeholderColor,
                        style = MaterialTheme.typography.bodyLarge
                    )
                },
                leadingIcon = resolvedLeadingIcon,
                trailingIcon = null,
                prefix = null,
                suffix = null,
                supportingText = null,
                shape = shape,
                colors = colors,
                contentPadding = contentPadding,
                container = {
                    TextFieldDefaults.Container(
                        enabled = enabled,
                        isError = false,
                        interactionSource = interactionSource,
                        shape = shape,
                        colors = colors
                    )
                }
            )
        }
    )
}

@Preview(showBackground = true, backgroundColor = 0xFFFFFFFF)
@Composable
private fun SearchFieldPreview() {
    MaterialTheme {
        Surface {
            val text = remember { mutableStateOf("") }
            SearchField(
                value = text.value,
                onValueChange = { text.value = it },
                placeholder = "Поиск по альбомам"
            )
        }
    }
}
