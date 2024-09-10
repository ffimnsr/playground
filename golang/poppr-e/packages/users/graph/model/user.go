package model

import (
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	ID           int       `json:"id"`
	ZitadelID    string    `json:"zitadelId" gorm:"unique"`
	Username     string    `json:"username" gorm:"unique"`
	PrimaryEmail string    `json:"primaryEmail" gorm:"unique"`
	DisplayName  string    `json:"displayName"`
	AvatarURL    string    `json:"avatarUrl"`
	Info         *UserInfo `json:"info" gorm:"foreignKey:UserID;references:ID"`
	Kyc          *UserKyc  `json:"kyc" gorm:"foreignKey:UserID;references:ID"`
}
