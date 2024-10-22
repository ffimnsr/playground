package com.se_same.passport

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform