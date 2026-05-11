package com.example.emotionapp.presentation.Onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.emotionapp.presentation.AppComponents.PrimaryButton
import kotlinx.coroutines.launch

data class OnboardingPage(
    val title: String,
    val description: String
)

@Composable
fun OnboardingScreen(
    vm: OnboardingViewModel,
    modifier: Modifier = Modifier,
    onFinish: () -> Unit,
) {
    val pages = remember {
        listOf(
            OnboardingPage(
                title = "Собирай мысли в одном месте",
                description = "Создавай заметки и структурируй их так, как удобно тебе"
            ),
            OnboardingPage(
                title = "Просто и понятно",
                description = "Управляй заметками с помощью альбомов и тем без лишних действий"
            ),
            OnboardingPage(
                title = "Умный анализ заметок",
                description = "Аналитика от ИИ помогает лучше понять твою активность"
            )
        )
    }

    val colors = MaterialTheme.colorScheme
    val pagerState = rememberPagerState(pageCount = { pages.size })
    val scope = rememberCoroutineScope()
    val isLastPage = pagerState.currentPage == pages.lastIndex

    Surface(
        modifier = modifier.fillMaxSize(),
        color = colors.background
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(56.dp))

            HorizontalPager(
                state = pagerState,
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
            ) { index ->
                OnboardingPageContent(page = pages[index])
            }

            PrimaryButton(
                text = if (isLastPage) "Начать" else "Далее",
                onClick = {
                    scope.launch {
                        if (isLastPage) {
                            vm.completeOnboarding()
                            onFinish()
                        }
                        else pagerState.animateScrollToPage(pagerState.currentPage + 1)
                    }
                }
            )

            Spacer(Modifier.height(16.dp))

            DotsIndicator(
                totalDots = pages.size,
                selectedIndex = pagerState.currentPage
            )

            Spacer(Modifier.height(24.dp))
        }
    }
}

@Composable
private fun OnboardingPageContent(page: OnboardingPage) {
    val colors = MaterialTheme.colorScheme

    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(150.dp)
                .background(colors.primary, RoundedCornerShape(24.dp)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Иконка",
                color = colors.onPrimary,
                style = MaterialTheme.typography.labelLarge,
                textAlign = TextAlign.Center
            )
        }

        Spacer(Modifier.height(32.dp))

        Text(
            text = page.title,
            color = colors.onBackground,
            style = MaterialTheme.typography.headlineMedium,
            textAlign = TextAlign.Center
        )

        Spacer(Modifier.height(12.dp))

        Text(
            text = page.description,
            color = colors.onSurfaceVariant,
            style = MaterialTheme.typography.bodyLarge,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun DotsIndicator(
    totalDots: Int,
    selectedIndex: Int
) {
    val colors = MaterialTheme.colorScheme

    Row(
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(totalDots) { index ->
            val isSelected = index == selectedIndex
            Box(
                modifier = Modifier
                    .size(if (isSelected) 12.dp else 9.dp)
                    .background(
                        color = if (isSelected) colors.primary else colors.primary.copy(alpha = 0.45f),
                        shape = CircleShape
                    )
            )
        }
    }
}
