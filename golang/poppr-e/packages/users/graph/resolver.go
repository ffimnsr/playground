package graph

import (
	"github.com/minio/minio-go/v7"
	"gorm.io/gorm"
)

//go:generate go run github.com/99designs/gqlgen generate

type Resolver struct {
	DB      *gorm.DB
	Storage *minio.Client
}
