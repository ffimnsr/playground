package common

import (
	"github.com/ffimnsr/poppr-users/graph/model"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func InitDb() (*gorm.DB, error) {
	dsn := "host=localhost user=postgres password=secret dbname=poppr-users port=5432 sslmode=disable TimeZone=Asia/Manila"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})

	if err != nil {
		return nil, err
	}

	db.AutoMigrate(&model.User{})
	db.AutoMigrate(&model.UserInfo{})
	db.AutoMigrate(&model.UserKyc{})
	db.AutoMigrate(&model.EmailAddress{})
	db.AutoMigrate(&model.PhoneNumber{})
	db.AutoMigrate(&model.Address{})

	return db, nil
}
