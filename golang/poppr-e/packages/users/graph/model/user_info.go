package model

import (
	"time"
)

type UserInfo struct {
	ID           int             `json:"id"`
	UserID       int             `json:"userId" gorm:"unique"`
	Emails       []*EmailAddress `json:"emails" gorm:"foreignKey:UserID;references:UserID"`
	PhoneNumbers []*PhoneNumber  `json:"phoneNumbers" gorm:"foreignKey:UserID;references:UserID"`
	Addresses    []*Address      `json:"addresses" gorm:"foreignKey:UserID;references:UserID"`
	BirthDate    time.Time       `json:"birthDate"`
	BirthGender  string          `json:"birthGender"`
}
