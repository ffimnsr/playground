package common

import (
	"github.com/ffimnsr/poppr-internal/graph/model"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func InitDb() (*gorm.DB, error) {
	dsn := "host=localhost user=postgres password=secret dbname=poppr-internal port=5432 sslmode=disable TimeZone=Asia/Manila"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})

	if err != nil {
		return nil, err
	}

	db.AutoMigrate(&model.Country{})
	db.AutoMigrate(&model.Region{})
	db.AutoMigrate(&model.Province{})
	db.AutoMigrate(&model.CityMunicipality{})
	db.AutoMigrate(&model.GlobalRole{})

	db.Create(&model.Country{
		ID:           1,
		Name:         "Philippines",
		Alpha2:       "PH",
		Alpha3:       "PHL",
		PhoneCode:    "+63",
		CurrencyCode: "PHP",
	})

	db.Create([]*model.GlobalRole{
		{ID: 1, Name: "Super Admin"},
		{ID: 2, Name: "Admin"},
		{ID: 3, Name: "User"},
		{ID: 4, Name: "Guest"},
	})

	return db, nil
}
