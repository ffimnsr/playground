package graph

// This file will be automatically regenerated based on the schema, any resolver implementations
// will be copied through when generating and any unknown code will be moved to the end.
// Code generated by github.com/99designs/gqlgen version v0.17.45

import (
	"context"
	"errors"
	"fmt"
	"io"
	"path/filepath"
	"strconv"
	"time"

	"github.com/ffimnsr/poppr-users/graph/model"
	minio "github.com/minio/minio-go/v7"
)

// CreateUserMinimal is the resolver for the createUserMinimal field.
func (r *mutationResolver) CreateUserMinimal(ctx context.Context, input model.NewUser) (*model.User, error) {
	emails := []*model.EmailAddress{
		{
			EmailAddress: input.PrimaryEmail,
			Primary:      true,
		},
	}

	data := model.User{
		ZitadelID:    input.ZitadelID,
		Username:     input.Username,
		PrimaryEmail: input.PrimaryEmail,
		DisplayName:  input.DisplayName,
		Info: &model.UserInfo{
			Emails: emails,
		},
	}

	if err := r.DB.Create(&data).Error; err != nil {
		return nil, err
	}

	return &data, nil
}

// CreateUserFull is the resolver for the createUserFull field.
func (r *mutationResolver) CreateUserFull(ctx context.Context, input model.NewUserFull) (*model.User, error) {
	emails := []*model.EmailAddress{
		{
			EmailAddress: input.PrimaryEmail,
			Primary:      true,
		},
	}

	data := model.User{
		ZitadelID:    input.ZitadelID,
		Username:     input.Username,
		PrimaryEmail: input.PrimaryEmail,
		DisplayName:  input.DisplayName,
		Kyc: &model.UserKyc{
			FirstName:  input.FirstName,
			LastName:   input.LastName,
			MiddleName: input.MiddleName,
		},
		Info: &model.UserInfo{
			Emails:      emails,
			BirthDate:   input.BirthDate,
			BirthGender: string(input.BirthGender),
		},
	}

	if err := r.DB.Create(&data).Error; err != nil {
		return nil, err
	}

	return &data, nil
}

// CreateUserProfile is the resolver for the createUserProfile field.
func (r *mutationResolver) CreateUserProfile(ctx context.Context, input model.NewUserProfile) (*model.User, error) {
	data := model.User{
		DisplayName: input.DisplayName,
		Info: &model.UserInfo{
			BirthDate:   input.BirthDate,
			BirthGender: string(input.BirthGender),
		},
		Kyc: &model.UserKyc{
			FirstName:  input.FirstName,
			LastName:   input.LastName,
			MiddleName: input.MiddleName,
		},
	}

	if err := r.DB.Create(&data).Error; err != nil {
		return nil, err
	}

	return &data, nil
}

// CreateEmailAddress is the resolver for the createEmailAddress field.
func (r *mutationResolver) CreateEmailAddress(ctx context.Context, input model.NewEmailAddress) (*model.EmailAddress, error) {
	data := model.EmailAddress{
		UserID:       input.UserID,
		EmailAddress: input.EmailAddress,
	}

	if err := r.DB.Create(&data).Error; err != nil {
		return nil, err
	}
	return &data, nil
}

// CreatePhoneNumber is the resolver for the createPhoneNumber field.
func (r *mutationResolver) CreatePhoneNumber(ctx context.Context, input model.NewPhoneNumber) (*model.PhoneNumber, error) {
	data := model.PhoneNumber{
		UserID:      input.UserID,
		PhoneNumber: input.PhoneNumber,
	}

	if err := r.DB.Create(&data).Error; err != nil {
		return nil, err
	}
	return &data, nil
}

// CreateAddress is the resolver for the createAddress field.
func (r *mutationResolver) CreateAddress(ctx context.Context, input model.NewAddress) (*model.Address, error) {
	data := model.Address{
		UserID:        input.UserID,
		StreetAddress: input.StreetAddress,
		Locality:      input.Locality,
		Region:        input.Region,
		Country:       input.Country,
		PostalCode:    input.PostalCode,
	}

	err := r.DB.Create(&data).Error
	if err != nil {
		return nil, err
	}
	return &data, nil
}

// UploadAvatar is the resolver for the uploadAvatar field.
func (r *mutationResolver) UploadAvatar(ctx context.Context, input model.NewUploadAvatar) (*model.User, error) {
	_, err := io.ReadAll(input.ImageFile.File)
	if err != nil {
		return nil, err
	}

	timestamp := strconv.FormatInt(time.Now().UTC().UnixNano(), 10)
	extension := filepath.Ext(input.ImageFile.Filename)
	filename := fmt.Sprintf("%s-%s%s", timestamp, strconv.Itoa(input.UserID), extension)
	upload, err := r.Storage.PutObject(ctx, "poppr-e-avatars", filename, input.ImageFile.File, input.ImageFile.Size, minio.PutObjectOptions{
		ContentType: "application/octet-stream",
	})

	if err != nil {
		return nil, err
	}

	data := model.User{
		ID:        input.UserID,
		AvatarURL: upload.Location,
	}
	if err = r.DB.Save(&data).Error; err != nil {
		return nil, err
	}
	return &data, nil
}

// UpdateUserInfo is the resolver for the updateUserInfo field.
func (r *mutationResolver) UpdateUserInfo(ctx context.Context, input model.ChangeUserInfo) (bool, error) {
	data := model.UserInfo{
		UserID:      input.UserID,
		BirthDate:   input.BirthDate,
		BirthGender: string(input.BirthGender),
	}

	if err := r.DB.Save(&data).Error; err != nil {
		return false, err
	}
	return true, nil
}

// UpdateUserKyc is the resolver for the updateUserKyc field.
func (r *mutationResolver) UpdateUserKyc(ctx context.Context, input model.ChangeUserKyc) (bool, error) {
	data := model.UserKyc{
		UserID:     input.UserID,
		FirstName:  input.FirstName,
		LastName:   input.LastName,
		MiddleName: input.MiddleName,
	}

	if err := r.DB.Save(&data).Error; err != nil {
		return false, err
	}
	return true, nil
}

// SetPrimaryEmailAddress is the resolver for the setPrimaryEmailAddress field.
func (r *mutationResolver) SetPrimaryEmailAddress(ctx context.Context, input model.LinkEmailAddress) (bool, error) {
	// TODO: Implement update on all user email disabling primary then set to one primary
	data := model.EmailAddress{
		ID:      input.EmailAddressID,
		UserID:  input.UserID,
		Primary: true,
	}
	if err := r.DB.Save(&data).Error; err != nil {
		return false, err
	}

	return true, nil
}

// SetPrimaryPhoneNumber is the resolver for the setPrimaryPhoneNumber field.
func (r *mutationResolver) SetPrimaryPhoneNumber(ctx context.Context, input model.LinkPhoneNumber) (bool, error) {
	data := model.PhoneNumber{
		ID:      input.PhoneNumberID,
		UserID:  input.UserID,
		Primary: true,
	}
	if err := r.DB.Save(&data).Error; err != nil {
		return false, err
	}

	return true, nil
}

// SetPrimaryAddress is the resolver for the setPrimaryAddress field.
func (r *mutationResolver) SetPrimaryAddress(ctx context.Context, input model.LinkAddress) (bool, error) {
	data := model.Address{
		ID:      input.AddressID,
		UserID:  input.UserID,
		Primary: true,
	}
	if err := r.DB.Save(&data).Error; err != nil {
		return false, err
	}

	return true, nil
}

// DeleteEmailAddress is the resolver for the deleteEmailAddress field.
func (r *mutationResolver) DeleteEmailAddress(ctx context.Context, input model.LinkEmailAddress) (bool, error) {
	if err := r.DB.Delete(&model.EmailAddress{ID: input.EmailAddressID, UserID: input.UserID}).Error; err != nil {
		return false, err
	}
	return true, nil
}

// DeletePhoneNumber is the resolver for the deletePhoneNumber field.
func (r *mutationResolver) DeletePhoneNumber(ctx context.Context, input model.LinkPhoneNumber) (bool, error) {
	if err := r.DB.Delete(&model.PhoneNumber{ID: input.PhoneNumberID, UserID: input.UserID}).Error; err != nil {
		return false, err
	}
	return true, nil
}

// DeleteAddress is the resolver for the deleteAddress field.
func (r *mutationResolver) DeleteAddress(ctx context.Context, input model.LinkAddress) (bool, error) {
	panic(fmt.Errorf("not implemented: DeleteAddress - deleteAddress"))
}

// VerifyUserKyc is the resolver for the verifyUserKyc field.
func (r *mutationResolver) VerifyUserKyc(ctx context.Context, id int) (bool, error) {
	err := r.DB.Model(&model.UserKyc{}).Where("user_id = ?", id).Update("verified_at", "NOW()").Error
	if err != nil {
		return false, err
	}
	return true, nil
}

// VerifyEmailAddress is the resolver for the verifyEmailAddress field.
func (r *mutationResolver) VerifyEmailAddress(ctx context.Context, input model.LinkEmailAddress) (bool, error) {
	err := r.DB.Model(&model.EmailAddress{}).
		Where("id = ? and user_id = ?", input.EmailAddressID, input.UserID).
		Update("verified_at", "NOW()").
		Error
	if err != nil {
		return false, err
	}
	return true, nil
}

// VerifyPhoneNumber is the resolver for the verifyPhoneNumber field.
func (r *mutationResolver) VerifyPhoneNumber(ctx context.Context, input model.LinkPhoneNumber) (bool, error) {
	err := r.DB.Model(&model.PhoneNumber{}).
		Where("id = ? and user_id = ?", input.PhoneNumberID, input.UserID).
		Update("verified_at", "NOW()").
		Error
	if err != nil {
		return false, err
	}
	return true, nil
}

// Users is the resolver for the users field.
func (r *queryResolver) Users(ctx context.Context) ([]*model.User, error) {
	var users []*model.User
	err := r.DB.
		Preload("Info").
		Preload("Info.Emails").
		Preload("Kyc").
		Find(&users).Error
	if err != nil {
		return nil, err
	}
	return users, nil
}

// VerifiedUsers is the resolver for the verifiedUsers field.
func (r *queryResolver) VerifiedUsers(ctx context.Context) ([]*model.User, error) {
	var users []*model.User
	err := r.DB.
		Joins("Kyc").
		Where("verified_at IS NOT NULL").
		Find(&users).Error
	if err != nil {
		return nil, err
	}
	return users, nil
}

// DeletedUsers is the resolver for the deletedUsers field.
func (r *queryResolver) DeletedUsers(ctx context.Context) ([]*model.User, error) {
	var users []*model.User
	err := r.DB.Where("deleted_at IS NOT NULL").Find(&users).Error
	if err != nil {
		return nil, err
	}
	return users, nil
}

// User is the resolver for the user field.
func (r *queryResolver) User(ctx context.Context, id int) (*model.User, error) {
	var user *model.User
	err := r.DB.
		Preload("Info").
		Preload("Info.Emails").
		Preload("Info.PhoneNumbers").
		Preload("Info.Addresses").
		Preload("Kyc").
		First(&user, id).Error
	if err != nil {
		return nil, err
	}
	return user, nil
}

// UserAddress is the resolver for the userAddress field.
func (r *queryResolver) UserAddress(ctx context.Context, id int) (*model.Address, error) {
	var user *model.User
	err := r.DB.
		Preload("Info").
		Preload("Info.Addresses").
		First(&user, id).
		Error
	if err != nil {
		return nil, err
	}
	if len(user.Info.Addresses) < 1 {
		return nil, errors.New("no addresses found")
	}

	return user.Info.Addresses[0], nil
}

// IsUserVerified is the resolver for the isUserVerified field.
func (r *queryResolver) IsUserVerified(ctx context.Context, id int) (bool, error) {
	var user *model.User
	if err := r.DB.Preload("Kyc").First(&user, id).Error; err != nil {
		return false, err
	}

	return user.Kyc.VerifiedAt != nil, nil
}

// BirthGender is the resolver for the birthGender field.
func (r *userInfoResolver) BirthGender(ctx context.Context, obj *model.UserInfo) (model.BirthGender, error) {
	return model.BirthGender(obj.BirthGender), nil
}

// Mutation returns MutationResolver implementation.
func (r *Resolver) Mutation() MutationResolver { return &mutationResolver{r} }

// Query returns QueryResolver implementation.
func (r *Resolver) Query() QueryResolver { return &queryResolver{r} }

// UserInfo returns UserInfoResolver implementation.
func (r *Resolver) UserInfo() UserInfoResolver { return &userInfoResolver{r} }

type mutationResolver struct{ *Resolver }
type queryResolver struct{ *Resolver }
type userInfoResolver struct{ *Resolver }