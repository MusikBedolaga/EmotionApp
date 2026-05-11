package com.example.emotionapp.presentation.utils

fun notesCountText(count: Int): String {
    val n = kotlin.math.abs(count)
    val lastTwo = n % 100
    val last = n % 10

    val word = when {
        lastTwo in 11..14 -> "заметок"
        last == 1 -> "заметка"
        last in 2..4 -> "заметки"
        else -> "заметок"
    }

    return "$count $word"
}
