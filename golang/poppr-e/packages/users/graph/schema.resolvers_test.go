package graph

import (
	"context"
	"log"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func NewMockDB() (*gorm.DB, sqlmock.Sqlmock) {
	db, mock, err := sqlmock.New(sqlmock.QueryMatcherOption(sqlmock.QueryMatcherEqual))
	if err != nil {
		log.Fatalf("an error '%s' was not expected when opening a stub database connection", err)
	}
	gdb, err := gorm.Open(postgres.New(postgres.Config{
		Conn: db,
	}), &gorm.Config{})
	if err != nil {
		log.Fatalf("an error '%s' was not expected when opening a gorm database connection", err)
	}
	return gdb, mock
}

func TestListUsers(t *testing.T) {
	db, mock := NewMockDB()
	assert.NotNil(t, db)

	rows := sqlmock.NewRows([]string{"id", "display_name"}).
		AddRow(1, "John Doe")

	mock.ExpectQuery("SELECT * FROM \"users\"").WillReturnRows(rows)

	resolv := Resolver{DB: db}
	users, err := resolv.Query().Users(context.TODO())
	assert.Nil(t, err)

	assert.Equal(t, 1, len(users))
	assert.Equal(t, 1, users[0].ID)
	assert.Equal(t, "John Doe", users[0].DisplayName)

	err = mock.ExpectationsWereMet()
	assert.Nil(t, err)
}
