from datetime import datetime, timezone
from typing import Dict, Any, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    create_refresh_token,
    hash_token,
)
from app.models.refresh_token import RefreshToken
from app.models.user import User
from app.services.user_service import UserService


class AuthService:
    @staticmethod
    def create_token_pair(db: Session, user_id: int) -> Dict[str, Any]:
        """
        Issues an initial access token and opaque refresh token pair upon login.
        """
        access_token = create_access_token(user_id)
        raw_refresh_token, token_hash, expire = create_refresh_token()

        token_record = RefreshToken(
            token_jti=token_hash,
            user_id=user_id,
            expires_at=expire,
            revoked=False,
        )
        db.add(token_record)
        db.commit()

        return {
            "access_token": access_token,
            "refresh_token": raw_refresh_token,
            "token_type": "bearer",
        }

    @staticmethod
    def rotate_refresh_token(db: Session, refresh_token_str: str) -> Dict[str, Any]:
        """
        Performs Refresh Token Rotation with Reuse Detection for Opaque Tokens.
        - If the token is valid & not revoked:
            Rotates the token by invalidating it and issuing a new pair.
        - If the token was ALREADY REVOKED (Reuse attack detected):
            Immediately revokes all refresh tokens for that user.
        """
        if not refresh_token_str or not refresh_token_str.strip():
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or empty refresh token",
                headers={"WWW-Authenticate": "Bearer"},
            )

        token_hash = hash_token(refresh_token_str.strip())

        token_record = (
            db.query(RefreshToken)
            .filter(RefreshToken.token_jti == token_hash)
            .first()
        )

        if not token_record:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or unrecognized refresh token",
                headers={"WWW-Authenticate": "Bearer"},
            )

        user_id = token_record.user_id

        # Reuse Detection: If an already-revoked refresh token is sent,
        # someone might have stolen the token. Revoke all tokens for this user!
        if token_record.revoked:
            db.query(RefreshToken).filter(RefreshToken.user_id == user_id).update(
                {RefreshToken.revoked: True}
            )
            db.commit()
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token reuse detected. All user sessions have been revoked for security.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Check expiration
        now = datetime.now(timezone.utc)
        expires_at = token_record.expires_at
        if expires_at.tzinfo is None:
            expires_at = expires_at.replace(tzinfo=timezone.utc)

        if expires_at < now:
            token_record.revoked = True
            db.commit()
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token has expired",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Check user status
        user = UserService.get_by_id(db, user_id=user_id)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User account is inactive or not found",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Generate new pair and rotate
        new_access_token = create_access_token(user.id)
        new_raw_refresh_token, new_token_hash, new_expire = create_refresh_token()

        # Invalidate old token and link to replacement
        token_record.revoked = True
        token_record.replaced_by = new_token_hash

        # Save new active token
        new_record = RefreshToken(
            token_jti=new_token_hash,
            user_id=user.id,
            expires_at=new_expire,
            revoked=False,
        )
        db.add(new_record)
        db.commit()

        return {
            "access_token": new_access_token,
            "refresh_token": new_raw_refresh_token,
            "token_type": "bearer",
        }

    @staticmethod
    def revoke_refresh_token(db: Session, refresh_token_str: str) -> None:
        """
        Explicitly revokes a refresh token (e.g. during logout).
        """
        if refresh_token_str and refresh_token_str.strip():
            token_hash = hash_token(refresh_token_str.strip())
            db.query(RefreshToken).filter(RefreshToken.token_jti == token_hash).update(
                {RefreshToken.revoked: True}
            )
            db.commit()
