package com.example.flutter_application_1

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.graphics.Color
import androidx.glance.*
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.*
import androidx.glance.text.*
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import androidx.glance.color.ColorProvider
import androidx.glance.state.GlanceStateDefinition

class TodoWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val prefs = currentState.preferences
        val remaining = prefs.getInt("remainingCount", 0)
        val done = prefs.getInt("doneCount", 0)
        val total = prefs.getInt("totalCount", 0)

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(Color(0xFF1C1C1E))
                .padding(16.dp)
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize()
            ) {
                // Title
                Text(
                    text = "Taskora",
                    style = TextStyle(
                        color = ColorProvider(day = Color.White, night = Color.White),
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                )

                Spacer(modifier = GlanceModifier.height(12.dp))

                // Stats row
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Remaining
                    Column(
                        modifier = GlanceModifier.defaultWeight(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = remaining.toString(),
                            style = TextStyle(
                                color = ColorProvider(day = Color(0xFF6366F1), night = Color(0xFF6366F1)),
                                fontSize = 28.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Text(
                            text = "Remaining",
                            style = TextStyle(
                                color = ColorProvider(day = Color(0xFFAAAAAA), night = Color(0xFFAAAAAA)),
                                fontSize = 11.sp
                            )
                        )
                    }

                    // Done
                    Column(
                        modifier = GlanceModifier.defaultWeight(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = done.toString(),
                            style = TextStyle(
                                color = ColorProvider(day = Color(0xFF00C875), night = Color(0xFF00C875)),
                                fontSize = 28.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Text(
                            text = "Done",
                            style = TextStyle(
                                color = ColorProvider(day = Color(0xFFAAAAAA), night = Color(0xFFAAAAAA)),
                                fontSize = 11.sp
                            )
                        )
                    }

                    // Total
                    Column(
                        modifier = GlanceModifier.defaultWeight(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = total.toString(),
                            style = TextStyle(
                                color = ColorProvider(day = Color.White, night = Color.White),
                                fontSize = 28.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Text(
                            text = "Total",
                            style = TextStyle(
                                color = ColorProvider(day = Color(0xFFAAAAAA), night = Color(0xFFAAAAAA)),
                                fontSize = 11.sp
                            )
                        )
                    }
                }
            }
        }
    }
}
