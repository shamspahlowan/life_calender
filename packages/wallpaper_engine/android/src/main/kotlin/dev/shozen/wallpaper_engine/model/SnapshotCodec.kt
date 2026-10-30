package dev.shozen.wallpaper_engine.model

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/** Serializes snapshots for storage. An interface so the storage format can change without touching callers. */
interface SnapshotCodec {
    fun encode(snapshot: WallpaperSnapshot): String

    /** @throws UnsupportedSchemaException when [text] was written by an incompatible schema. */
    fun decode(text: String): WallpaperSnapshot
}

class UnsupportedSchemaException(val version: Int?) :
    IllegalArgumentException("Unsupported snapshot schema version: $version")

class JsonSnapshotCodec(
    private val json: Json = Json { ignoreUnknownKeys = true; encodeDefaults = true },
) : SnapshotCodec {

    override fun encode(snapshot: WallpaperSnapshot): String =
        json.encodeToString(WallpaperSnapshot.serializer(), snapshot)

    override fun decode(text: String): WallpaperSnapshot {
        // Check the version before decoding the body: a future schema may not decode at all.
        val version = runCatching {
            json.parseToJsonElement(text).jsonObject["schemaVersion"]?.jsonPrimitive?.int
        }.getOrNull()
        if (version != WallpaperSnapshot.CURRENT_SCHEMA_VERSION) throw UnsupportedSchemaException(version)
        return json.decodeFromString(WallpaperSnapshot.serializer(), text)
    }
}
