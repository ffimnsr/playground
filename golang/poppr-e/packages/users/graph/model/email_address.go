package model

import (
	"time"
)

type EmailAddress struct {
	ID           int        `json:"id"`
	UserID       int        `json:"userId"`
	EmailAddress string     `json:"emailAddress" gorm:"unique"`
	Primary      bool       `json:"primary"`
	VerifiedAt   *time.Time `json:"verifiedAt"`
}
