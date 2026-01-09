"""
服务包
"""
from .auth_service import (
    get_current_user,
    authenticate_user,
    create_access_token,
    get_password_hash,
    verify_password,
)

from .music_service import (
    get_music_by_id,
    get_user_musics,
    get_user_musics_with_favorite,
    delete_music,
    add_to_collection,
    remove_from_collection,
    toggle_favorite,
    get_user_collections,
    get_user_collections_with_tags,
    get_user_journal,
    get_user_stats,
    increment_play_count,
    create_music,
    update_music_status,
    get_music_list,
    get_music_detail,
)

from .user_service import (
    get_user_settings,
    update_user_settings,
    update_user_profile,
)

__all__ = [
    # Auth service
    "get_current_user",
    "authenticate_user",
    "create_access_token",
    "get_password_hash",
    "verify_password",
    # Music service
    "get_music_by_id",
    "get_user_musics",
    "get_user_musics_with_favorite",
    "delete_music",
    "add_to_collection",
    "remove_from_collection",
    "toggle_favorite",
    "get_user_collections",
    "get_user_collections_with_tags",
    "get_user_journal",
    "get_user_stats",
    "increment_play_count",
    "create_music",
    "update_music_status",
    "get_music_list",
    "get_music_detail",
    # User service
    "get_user_settings",
    "update_user_settings",
    "update_user_profile",
]
